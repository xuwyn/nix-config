{
  hjemCompat = true;
  tags = ["desktop"];
  module = {inputs, ...}: {
    hj.files = {
      "Pictures/Wallpapers".source = "${inputs.assets}/wallpapers";
      ".face".source = "${inputs.assets}/face.jpg";
    };
  };
}
