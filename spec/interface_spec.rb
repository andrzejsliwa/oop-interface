RSpec.describe Interface do
  module Order
    def submit; end
    def add_position(_position); end
  end

  module Saver
    def save; end
  end

  class OrderImpl
    include Interface
    implements Order, Saver
    def submit
      :submitted
    end

    def save(some: 5)
      "save #{some}"
    end
  end

  it "implements interface" do
    order = OrderImpl.new
    expect(order).to be_a Saver
    expect(order).to be_a Order
    expect(order.submit).to eq :submitted
    expect {
      order.add_position
    }.to raise_error NotImplementedError
  end

  describe "#as" do
    it "limits the scope to specific interface" do
      order = OrderImpl.new
      saver = order.as(Saver)
      expect {
        saver.submit
      }.to raise_error NoMethodError
      expect(saver).to be_a(Saver)
      expect(saver.save(some: 7)).to eq "save 7"
    end

    it "returns same class object per interface" do
      order1 = OrderImpl.new.as(Saver)
      order2 = OrderImpl.new.as(Saver)
      expect(order1.class).to eq(order2.class)
    end
  end

  describe ".interfaces" do
    subject { OrderImpl.interfaces }
    it { should eq [Order, Saver] }
  end

  describe ".unimplemented_methods" do
    subject { OrderImpl.unimplemented_methods }
    it do
      should eq(Order => [:add_position])
    end
  end
end
