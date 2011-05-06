require "spec_helper"

describe SupervisionRedisPublisher do
  class Model
    include SupervisionRedisPublisher

    def supervision_id
      42
    end

    def supervision_publish_attributes
      {:only => :id}
    end

    def to_json(attributes)
      %Q[{"model":{"id":42}}]
    end
  end

  subject { Model.new }

  it { should respond_to :publish_to_redis }

  describe "#publish_to_redis" do
    it "should serialize object to JSON" do
      attributes = subject.supervision_publish_attributes
      subject.should_receive(:supervision_publish_attributes).and_return(attributes)
      subject.should_receive(:to_json)
      subject.publish_to_redis
    end

    it "should publish serialized object to Redis channel" do
      json_string = subject.to_json(subject.supervision_publish_attributes)
      REDIS.should_receive(:publish).with("supervision:42", json_string)
      subject.publish_to_redis
    end
  end
end
