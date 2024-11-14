self: super: {
  warpd = super.warpd.override {
    withWayland = true;
    withX = false;
  };
}
