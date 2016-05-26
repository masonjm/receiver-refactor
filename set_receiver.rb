class SetReceiver < Base
  attr_reader :receiver

  def call
    login
    find_receiver
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
    search_for_receiver do
      return edit_receiver if receiver_found?
      return new_receiver if receiver_not_found?
      # TODO: Raise error about too many matches
    end
  end

  def new_receiver
    click_link "New Receiver"
    find(".hwType").select(receiver.model)
  end

  def receiver_found?
    has_content?("1 Item Found")
  end

  def receiver_not_found?
    has_content?("No Items Found")
  end

  def save
    accept_alert do
      click_button "Save"
    end
  end

  def search_for_receiver
    goto_page :receivers_list
    within("#SearchTopRow") do
      select "Serial Number"
    end
    find("#ctl00_ctl00_ContentPlaceHolder1_SearchTermTextBox1").set receiver.serial_number
    click_button "Search"
    yield if block_given? # Do stuff with the search results page
  end
end
