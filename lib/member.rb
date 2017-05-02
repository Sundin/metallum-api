require 'nokogiri'

class Member

  def self.show_member_page(html)
    page = Nokogiri::HTML(html)

    member = {
        # TODO
    }

    member
  end
end
