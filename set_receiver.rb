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
    # TODO: raise error if login fails
  end

  def logout
    click_link "Logout"
  end

  def initialize(*args)
    super

    Capybara.default_driver = :selenium # TODO make this configurable so we can use polgergeist when not developing
  end

  attr_accessor :receiver

  def call(receiver:)
    self.receiver = receiver
    login
    goto_page :receivers_list

    case find_receiver
    when :found
      edit_receiver
    when :not_found
      new_receiver
    else
      # TODO: Raise error about too many matches
    end

    assign_attributes
    save
    logout
  end

  def assign_attributes
    find("#ctl00_ctl00_ContentPlaceHolder1_ChildContent3__descriptionTextBox").set receiver.notes
    find("#ctl00_ctl00_ContentPlaceHolder1_ChildContent3__serialNumberTextBox").set receiver.serial_number
    # TODO: timezone selection
    check "Activated"
  end

  def edit_receiver
    within("td.Info") do
      find("a").click
      find("div", text: "Edit").click
    end
  end

  def find_receiver
    within("#SearchTopRow") do
      select "Serial Number"
    end
    find("#ctl00_ctl00_ContentPlaceHolder1_SearchTermTextBox1").set receiver.serial_number
    click_button "Search"

    if has_content?("1 Item Found")
      :found
    elsif has_content?("No Items Found")
      :not_found
    else
      :multiple_results
    end
  end

  def new_receiver
    click_link "New Receiver"
    find(".hwType").select(receiver.model)
  end

  def save
    accept_alert do
      click_button "Save"
    end
  end
end
