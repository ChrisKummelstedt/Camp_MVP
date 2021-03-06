feature "Team Membership" do
  before do
    user = create :user
  end
  after do
    remove_uploaded_file
  end
  scenario "Join a team correctly" do
    create_project
    create_team
    first('.table').click_link("Coding Team")
    expect(page).to have_content("myUsername")
  end

  scenario "Join team as not the creator" do
    create_project
    create_team
    click_link ("Logout")
    sign_up("asdf", "asdf@asdf.com")
    click_link "awesome project title"
    first('.table').click_link("Coding Team")
    click_button("Join Team")
    expect(page).to have_content("Successfully Join Team")
  end

  scenario "leave a team correctly" do
    create_project
    create_team
    first('.table').click_link("Coding Team")
    click_button "Leave Team"
    expect(page).not_to have_content("myUsername")
  end
end
