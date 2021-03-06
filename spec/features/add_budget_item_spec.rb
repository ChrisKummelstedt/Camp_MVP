
feature "Budget item" do
  after do
    remove_uploaded_file
  end
  scenario "adding a budget item" do
    create_project
    create_team
    first('.table').click_link "Coding Team"
    fill_in("Budget item", with: "Hammer")
    fill_in("Quantity", with: 1)
    fill_in("Cost per item", with: 3)
    click_button "add_item"
    expect(page).to have_content("Hammer")
    expect(page).to have_content(1)
    expect(page).to have_content(3.0)
  end

  scenario "delete a budget item" do
    create_project
    create_team
    first('.table').click_link "Coding Team"
    fill_in("Budget item", with: "Hammer")
    fill_in("Quantity", with: 1)
    fill_in("Cost per item", with: 3)
    click_button "add_item"
    click_link("delete_item")
    expect(page).not_to have_content("Hammer")
    expect(page).not_to have_content(3.0)
  end

  scenario "adding a budget item updates team budget total" do
    create_project
    create_team
    first('.table').click_link "Coding Team"
    fill_in("Budget item", with: "Hammer")
    fill_in("Quantity", with: 1)
    fill_in("Cost per item", with: 3)
    click_button "add_item"
    expect(page).to have_content("Total Budget: 3.0")
  end

  scenario "delete a budget item" do
    create_project
    create_team
    first('.table').click_link "Coding Team"
    fill_in("Budget item", with: "Hammer")
    fill_in("Quantity", with: 1)
    fill_in("Cost per item", with: 3)
    click_button "add_item"
    click_link("delete_item")
    expect(page).to have_content("Total Budget: 0.0")
  end
end
