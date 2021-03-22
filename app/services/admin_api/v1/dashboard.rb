# frozen_string_literal: true

class AdminAPI::V1::Dashboard < API
  include Grape::Kaminari

  namespace :dashboard, desc: "仪表盘 API" do
    helpers do
      def order_line_chart_data(data_source)
        ((Date.current - 30.days)..Date.current).map { |date| [date, data_source.to_h[date] || 0] }.to_h
      end

      def recent_one_week_basic_data
        new_applications_count_array = Bean::Application.where.not(wechat_application_id: nil).recent_day(6).group("DATE(created_at)").count
        new_users_count_count_array = User.recent_day(6).group("DATE(created_at)").count

        (6.days.ago.to_date..Date.today).map do |date|
          { ref_date: date, new_applications_count: new_applications_count_array[date] || 0, new_users_count: new_users_count_count_array[date] || 0 }
        end
      end
    end

    desc "控制面板"
    get do
      if current_role.kind == "super"
        {
          wtpp_applications_count: Bean::Application.where.not(wechat_application_id: nil).count,
          applications_count: Bean::Application.count,
          users_count: User.count,
          recent_one_week: recent_one_week_basic_data.reverse
        }
      else
        # 订单/用户数据预览

        order_data_overview = {
          order_sum_pay_amount: current_store.orders.completed.sum(:total),
          today_order_count: current_store.orders.today.count,
          today_order_pay_amount: current_store.orders.today.completed.sum(:total),
          recent_7_day_order_count: current_store.orders.recent_day(7).count,
          recent_7_day_order_pay_amount: current_store.orders.recent_day(7).completed.sum(:total),
        }

        count_stats = {
          orders_count: current_store.orders.completed.count,
          wait_send_goods_count: current_store.orders.shipment_state_pending.count,
          # pending_after_sale_count: current_store.after_sales.pending.count,
          applied_count: current_store.orders.applied.count
        }

        order_scope = current_store.orders.recent_day(30)

        # 订单总数趋势
        @recent_30_order_num_trend = order_scope.group("DATE(completed_at)").count
        # 支付订单数趋势
        @recent_30_paid_order_num_trend = order_scope.completed.group("DATE(completed_at)").count
        # 销售总额趋势(所有支付金额总和)
        @recent_30_order_paid_amount_trend = order_scope.completed.group("DATE(completed_at)").sum(:total)
        recent_30_order_trend = {
          order_num_trend: order_line_chart_data(@recent_30_order_num_trend),
          paid_order_num_trend: order_line_chart_data(@recent_30_paid_order_num_trend),
          order_paid_amount_trend: order_line_chart_data(@recent_30_order_paid_amount_trend)
        }

        order_data_overview = order_data_overview.merge({
          user_count: current_application.users.count,
          today_new_user_count: current_application.users.today.count
        })

        {
          count_stats: count_stats,
          order_data_overview: order_data_overview,
          top10_products: current_store.products.select("bean_products.*, SUM(bean_store_variants.sales_volume) AS sales_volume").joins(variants: :store_variants).group("bean_products.id").order("sales_volume DESC").limit(10).map { |product| { id: product.id, name: product.name, sales_volume: product.sales_volume} },
          recent_30_order_trend: recent_30_order_trend,
        }
      end
    end

    desc "获取小程序PV、UV"
    params do
      optional :time_type, :string, values: ["yesterday", "the_day_before_yesterday", "one_week", "two_weeks", "one_month"]
    end
    get "visit_data" do
      return [] if current_wechat_application_client.blank?
      start_at, end_at =
        case params[:time_type]
        when "yesterday"
          [Date.current.yesterday, Date.current.yesterday]
        when "the_day_before_yesterday"
          [Date.current.prev_day(2), Date.current.yesterday]
        when "one_week"
          [Date.current - 1.week, Date.current.yesterday]
        when "two_weeks"
          [Date.current - 2.weeks, Date.current.yesterday]
        when "one_month"
          [Date.current - 1.month, Date.current.yesterday]
        else
          [Date.current - 1.week, Date.current.yesterday]
        end
      current_wechat_application_client.get_weanalysis_appid_daily_visit_trend(start_at, end_at).compact
    end
  end
end
