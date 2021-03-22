# frozen_string_literal: true

module Helpers
  module ErrorCodeHelper
    # 400
    HAS_WAIT_TO_PAY_ORDER = 40001
    APPLICATION_INVALID = 40002

    # 401
    USER_BLOCKED_CODE = 40101

    # 403
    APPLICATION_EXPIRED = 40302
    ADMIN_USERS_ROLE_REMOVED = 40303
  end
end
