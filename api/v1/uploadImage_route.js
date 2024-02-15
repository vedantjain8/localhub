const express = require("express");
const multer = require("multer");
const fs = require("fs");
const sharp = require("sharp");
const redisClient = require("../dbredis");
const { getUserData } = require("./functions/users");

const router = express.Router();

// const storage = multer.diskStorage({
//   destination: function (req, file, cb) {
//     cb(null, path.join(__dirname, "../upload"));
//   },
//   filename: function (req, file, cb) {
//     cb(null, `${Date.now()}-${file.originalname}`);
//   },
// });

const upload = multer({ storage: multer.memoryStorage() });

router.post("/upload", upload.single("uploaded_file"), async (req, res) => {
  try {
    const token = req.body.token;
    const user_id = JSON.parse(await getUserData(token))["user_id"];

    if (!user_id) {
      return response
        .status(400)
        .json({ status: 400, response: "Invalid name provided" });
    }

    // Create directories if they don't exist
    fs.access("./upload", (error) => {
      if (error) {
        fs.mkdirSync("./upload");
        fs.mkdirSync("./upload/low");
      }
    });

    const { buffer, originalname } = req.file;
    const ref = `${Date.now()}-${originalname}.webp`;

    // Convert and save original image
    // await sharp(buffer).toFile("./upload/original/" + ref);

    // Convert and save low-quality image
    await sharp(buffer)
      .webp({ quality: 20 })
      .toFile("./upload/low/" + ref);
    const link = `https://o8oqubodf2.starling-tet.ts.net/files/low/${ref}`;

    const out = { user_id: user_id, image_name: ref, image_url: link };
    console.log(out);

    await redisClient.hSet(
      "ImageUploadLog",
      `${token}:${ref}`,
      JSON.stringify(out)
    );

    return res.json({ status: 200, response: link });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({ status: 500, response: "Failed to upload file" });
  }
});

module.exports = router;
{
  /* <form action="http://localhost:3001/upload" enctype="multipart/form-data" method="post">
    <div class="form-group">
      <input type="file" class="form-control-file" name="uploaded_file">
      <input type="text" class="form-control" placeholder="Number of speakers" name="nspeakers">
      <input type="submit" value="Get me the stats!" class="btn btn-default">            
    </div>
  </form> */
}
