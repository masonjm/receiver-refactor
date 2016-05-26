class SetReceivers < Base
  def call(receivers: receiver_devices)
    receivers.each do |receiver|
      SetReceiver.(receiver: receiver)
    end
  end

  def receiver_devices
    Receiver.all
  end
end
