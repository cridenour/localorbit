require "spec_helper"

feature "User signs in" do
  let!(:admin) { create(:user, :admin) }
  let!(:market2) { create(:market) }
  let!(:org2) { create(:organization, markets: [market2]) }
  let!(:user2) { create(:user, organizations: [org2]) }

  let(:session_cookie_name) { "_LocalOrbit_session_data_test" }

  scenario 'with valid credentials' do
    visit "/"

    fill_in "Email", with: admin.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page).to have_text("Dashboard")
    expect(page.current_path).to eq(dashboard_path)
  end

  scenario 'as returning user and login remembered' do
    visit "/"
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password"
    check "Remember Me"
    click_button "Sign In"

    delete_cookie session_cookie_name

    visit new_user_session_path
    expect(page).to have_text("Dashboard")
  end

  # Make sure the cookie jar hack still works
  scenario 'as returning user and session is remembered' do
    visit "/"
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    delete_cookie session_cookie_name

    visit "/"
    expect(page).to_not have_text("Dashboard")
  end

  scenario "user signs out" do
    sign_in_as admin
    visit "/"
    click_link "Sign Out"
    expect(page).not_to have_text("Dashboard")
    expect(page).to have_text("Signed out successfully")
    expect(page).to have_text("Please Sign In")
  end

  scenario 'user attempts to sign in with invalid credentials' do
    user = build :user

    visit new_user_session_path

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign In'

    expect(page).to have_text 'Invalid email or password.'
    expect(page).to have_no_link 'Sign Out'
  end

  scenario "After logging in through the organizations page an admin should be on the organizations page" do
    visit admin_organizations_path

    fill_in "Email", with: admin.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(admin_organizations_path)
  end

  scenario "After logging in a market manager should be on the dashboard" do
    user = create(:user, :market_manager)
    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(dashboard_path)
  end

  scenario "After logging in through the organizations page a market manager should be on the organizations page" do
    user = create(:user, :market_manager)
    visit admin_organizations_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(admin_organizations_path)
  end

  scenario "After logging in a seller should be on the dashboard" do
    market = create(:market)
    org = create(:organization, :seller, markets: [market])
    user = create(:user, :supplier, organizations: [org])
    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(dashboard_path)
  end

  scenario "After logging in through the products page a seller should be on the products page" do
    market = create(:market)
    org = create(:organization, :seller, markets: [market])
    user = create(:user, :supplier, organizations: [org])
    visit admin_products_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(admin_products_path)
  end

  scenario "After logging in at the naked domain a buyer should be on the shop page" do
    market = create(:market)
    create(:delivery_schedule, market: market)
    org = create(:organization, :buyer, :single_location, markets: [market])
    user = create(:user, organizations: [org])

    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(products_path)
  end

  scenario "After logging in a buyer should be on the shop page" do
    market = create(:market)
    create(:delivery_schedule, market: market)
    org = create(:organization, :buyer, :single_location, markets: [market])
    user = create(:user, :buyer, organizations: [org])

    switch_to_subdomain market.subdomain

    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(products_path)
  end

  context "As a suspended user", :suspend_user do
    let!(:selling_user) { create(:user, :supplier, organizations: [org2]) }

    before do
      suspend_user(user: selling_user, org: org2)
    end

    scenario "logging in as a suspended user" do
      switch_to_subdomain(market2.subdomain)
      sign_in_as(selling_user)

      expect(page).to have_content("Your account has been suspended.")
    end
  end

  context "As a market manager logging into a market that they do not manage" do
    let!(:market_manager) { create(:user, :market_manager, managed_markets: [market1]) }
    let!(:market1) { create(:market) }
    let!(:market2) { create(:market) }

    scenario "sees 404" do
      switch_to_subdomain(market2.subdomain)
      sign_in_as(market_manager)

      expect(page).not_to have_content("suspended")
      expect(page).to have_content("The page you were looking for doesn't exist (404)")
    end
  end

  context "Signing into a deactivated market" do
    let!(:market) { create(:market, active: false) }
    let!(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }
    let!(:org) { create(:organization, markets: [market]) }
    let!(:buyer) { create(:user, :buyer, organizations: [org]) }

    scenario "as a market manager" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(market_manager)

      expect(page).to have_content("The market #{market.name} has been deactivated.")
    end

    scenario "as a buyer" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(buyer)

      expect(page).to have_content("The market #{market.name} has been deactivated.")
    end
  end
end
