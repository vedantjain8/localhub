const express = require("express");
const pool = require("../db");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const sharp = require("sharp");

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
  fs.access("./upload", (error) => {
    if (error) {
      fs.mkdirSync("./upload");
    //   fs.mkdirSync("./upload/original");
      fs.mkdirSync("./upload/low");
    }
  });
  const { buffer, originalname } = req.file;
  const ref = `${Date.now()}-${originalname}.webp`;
//   await sharp(buffer).toFile("./upload/original/" + ref);
  await sharp(buffer)
    .webp({ quality: 20 })
    .toFile("./upload/low/" + ref);
  console.log(ref);
  const link = `http://localhost:3000/${ref}`;
  return res.json({ link });
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
