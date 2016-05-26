class SetReceiver
  include Capybara::DSL
  include ServiceCall

  PAGE = {
    login:          "/int/login.aspx",
    receivers_list: "/int/receiverlist.aspx?level=1",
  }.map do |name, path|
    [name, "http://#{Rails.configuration.receiver_api[:host]}#{path}"]
  end.to_h.with_indifferent_access.freeze

  def goto_page(page)
    visit(PAGE[page])
  end

  def login
    goto_page :login
    fill_in "User Name", with: Rails.configuration.receiver_api[:username]
    fill_in "Password", with: Rails.configuration.receiver_api[:password]
    click_button "Log In"
  end

  def logout
    click_link "Logout"
  end

  def initialize(*args)
    super

    Capybara.default_driver = :selenium # TODO make this configurable so we can use polgergeist when not developing
  end

  def call(receivers: receiver_devices)
    login
    receivers.each do |receiver|
      goto_page :receivers_list
      # find the receiver
      within("#SearchTopRow") do
        select "Serial Number"
      end
      find("#ctl00_ctl00_ContentPlaceHolder1_SearchTermTextBox1").set receiver.serial_number
      click_button "Search"

      if has_content?("1 Item Found")
        # edit
        within("td.Info") do
          find("a").click
          find("div", text: "Edit").click
        end
      elsif has_content?("No Items Found")
        click_link "New Receiver"
        find(".hwType").select(receiver.model)
      else
        # TODO: Log error about too many matches
        next
      end

      find("#ctl00_ctl00_ContentPlaceHolder1_ChildContent3__descriptionTextBox").set receiver.notes
      find("#ctl00_ctl00_ContentPlaceHolder1_ChildContent3__serialNumberTextBox").set receiver.serial_number
      # TODO: timezone selection
      check "Activated"
      accept_alert do
        click_button "Save"
      end
    end
    logout
  end

  def receiver_devices
    Receiver.all
  end
end
