class Base
  include Capybara::DSL
  include ServiceCall

  PAGE = {
    login:          "/int/login.aspx",
    receivers_list: "/int/receiverlist.aspx?level=1",
  }.map do |name, path|
    [name, "http://#{Rails.configuration.receiver_api[:host]}#{path}"]
  end.to_h.with_indifferent_access.freeze

  # Visit a named URL
  def goto_page(page)
    visit(PAGE[page])
  end

  # Visit login page and fill in the form
  def login
    goto_page :login
    fill_in "User Name", with: Rails.configuration.receiver_api[:username]
    fill_in "Password", with: Rails.configuration.receiver_api[:password]
    click_button "Log In"
    # TODO: raise error if login fails
  end

  # Click the Logout link
  def logout
    click_link "Logout"
  end

  def initialize(*args)
    super

    Capybara.default_driver = :selenium # TODO: make this configurable so we can use poltergeist when not developing
  end
end
