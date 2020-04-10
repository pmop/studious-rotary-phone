module ReportsFactories
  def create_with_desc_user(desc, user_id)
    Report.create!(description: desc,
                   lat: 9.99,
                   lng: 9.99,
                   user_id: user_id)
  end
end
