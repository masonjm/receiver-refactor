class SetReceiver < Base
  attr_reader :receiver

  def call
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
    search_for_receiver

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

  def search_for_receiver
    within("#SearchTopRow") do
      select "Serial Number"
    end
    find("#ctl00_ctl00_ContentPlaceHolder1_SearchTermTextBox1").set receiver.serial_number
    click_button "Search"
  end
end
