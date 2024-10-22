mixin SetCategoryButtonMixin {
  String buttonNamePressed = ""; // State to share

  void setCategoryButtonPressed(String buttonName) {
    buttonNamePressed = buttonName;
  }

  String getCategoryButtonName() {
    return buttonNamePressed;
  }
}