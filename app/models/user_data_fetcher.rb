class UserDataFetcher
  def initialize(user)
    @user = user
  end

  def fetch
    @user
  end

  private

  def yammer_user_data
    yammer_client.get("/users/#{yammer_user_id}")
  end

  def yammer_client
    @yam ||= Yam.new(access_token, yammer_endpoint)
  end

  def access_token
    @user.access_token
  end
end
