require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  let(:zone) { "Pacific Time (US & Canada)" }

  describe "format_date" do
    context "when given nil" do
      it "returns nil" do
        expect(format_date(nil)).to be_nil
      end
    end

    context "when given blank" do
      it "returns nil" do
        expect(format_date("")).to be_nil
      end
    end

    context "when given 1 minute ago" do
      it "returns value in words" do
        expect(format_date(Time.now.in_time_zone(zone) - 1.1.minutes))
          .to eq("1 minute ago")
      end
    end

    context "when given 32 minutes ago" do
      it "returns value in words" do
        expect(format_date(Time.now.in_time_zone(zone) - 32.minutes))
          .to eq("32 minutes ago")
      end
    end

    context "when given more than an hour ago on the same day" do
      it "returns value as time" do
        Timecop.freeze("2020-10-02 04:32:00 -0700") do
          expect(format_date(Time.now.in_time_zone(zone) - 1.1.hours))
            .to eq("3:25am")
        end
      end
    end

    context "when given more than an hour ago on a different day" do
      it "returns value as date-time" do
        Timecop.freeze("2020-10-02 00:32:00 -0700") do
          expect(format_date(Time.now.in_time_zone(zone) - 1.1.hours))
            .to eq("10/1-11:25pm")
        end
      end
    end

    context "when given more than a week ago in the same year" do
      it "returns value as date-time" do
        Timecop.freeze("2020-10-02 04:32:00 -0700") do
          expect(format_date(Time.now.in_time_zone(zone) - 10.days))
            .to eq("9/22-4:32am")
        end
      end
    end

    context "when given more than a week ago in a different year" do
      it "returns value as date/year-time" do
        Timecop.freeze("2020-01-02 04:32:00 -0700") do
          expect(format_date(Time.now.in_time_zone(zone) - 10.days))
            .to eq("12/23/2019-3:32am")
        end
      end
    end
  end
end
