self: super: {
  warpd = super.warpd.override {
    withWayland = false;
    withX = true;
  };
}
