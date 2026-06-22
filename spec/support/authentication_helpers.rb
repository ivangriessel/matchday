module AuthenticationHelpers
  def sign_in_as(user)
    ps = Passwordless::Session.create!(
      authenticatable: user,
      expires_at: 1.hour.from_now,
      timeout_at: 1.hour.from_now
    )
    get confirm_auth_sign_in_path(ps, ps.token)
    follow_redirect!
  end
end
