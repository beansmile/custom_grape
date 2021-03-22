# frozen_string_literal: true

class AppAPI::V1::ActiveStorage < ::API
  namespace :active_storage, desc: "直传签名" do
    desc "获取阿里云签名", detail: <<-NOTES.strip_heredoc
      返回签名
      ```json
      {
        "id": 20,
        "key": "wv2a87cx2i4dypdqvc39hi85u1kt",
        "filename": "test.jpg",
        "content_type": "image/jpg",
        "metadata": {},
        "byte_size": 123,
        "checksum": "123",
        "created_at": "2020-07-06T17:00:32.579+08:00",
        "signed_id": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBHUT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--9e684a9c64d093b21ab764179c12649b7ca03827",
        "attachable_sgid": "BAh7CEkiCGdpZAY6BkVUSSJAZ2lkOi8vZnJlc2NvYmFsZGktYmFja2VuZC9BY3RpdmVTdG9yYWdlOjpCbG9iLzIwP2V4cGlyZXNfaW4GOwBUSSIMcHVycG9zZQY7AFRJIg9hdHRhY2hhYmxlBjsAVEkiD2V4cGlyZXNfYXQGOwBUMA==--a93a08ea6f30568388d6fe75b582de3da67fc0a7",
        "direct_upload": {
          "url": "https://test.cos.ap-guangzhou.myqcloud.com/wv2a87cx2i4dypdqvc39hi85u1kt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIDA4iETSvODoENHurND9pGNEothEUot9vJ%2F20200706%2Fap-guangzhou%2Fs3%2Faws4_request&X-Amz-Date=20200706T090032Z&X-Amz-Expires=300&X-Amz-SignedHeaders=content-length%3Bcontent-md5%3Bcontent-type%3Bhost&X-Amz-Signature=b11066de1f8800f361c6fc9b81b2cde1181bfe964eba6f8090160ef60a332a77",
          "headers": {
            "Content-Type": "image/jpg",
            "Content-MD5": "123"
          }
        }
      }
      ```
    NOTES
    params do
      requires :filename
      requires :byte_size, type: Integer
      requires :hex_digest
      requires :content_type
    end
    post "direct_upload" do
      blob = ActiveStorage::Blob.create_before_direct_upload!({
        filename: params[:filename],
        byte_size: params[:byte_size],
        checksum: [[params[:hex_digest]].pack("H*")].pack("m0"), # convert hexadecimal digest to base64
        content_type: params[:content_type]
      })

      blob.as_json(root: false, methods: :signed_id).merge(direct_upload: {
        url: blob.service_url_for_direct_upload,
        headers: blob.service_headers_for_direct_upload
      })
    end
  end
end
