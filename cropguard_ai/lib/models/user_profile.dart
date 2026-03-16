class UserProfile {
  static final UserProfile _instance = UserProfile._internal();
  
  factory UserProfile() {
    return _instance;
  }
  
  UserProfile._internal();
  
  String name = 'John Doe';
  String email = 'john.doe@farm.com';
  String phone = '+1 (555) 123-4567';
  String location = 'Green Valley, California';
  String crop = 'Wheat & Corn';
}
