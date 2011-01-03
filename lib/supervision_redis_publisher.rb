module SupervisionRedisPublisher
  def publish_to_redis
    json_string = to_json(supervision_publish_attributes)
    channel = "supervision:#{supervision_id}"
    REDIS.publish(channel, json_string)
    super if defined?(super)
  end
end
