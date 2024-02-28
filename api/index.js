const express = require("express");
const bodyParser = require("body-parser");
const helmet = require("helmet");
const { rateLimit } = require("express-rate-limit");
const morgan = require("morgan");
const https = require("https");
const http = require("http");
const fs = require("fs");
const path = require("path");

const createDirectories = require("./v1/functions/initCreateDirectory");

const userRoutes = require("./v1/user_routes");
const communityRoutes = require("./v1/community_routes");
const postRoutes = require("./v1/post_routes");
const commentRoutes = require("./v1/comments_routes");
const votesRoutes = require("./v1/votes_routes");
const reportRoutes = require("./v1/report_routes");
const meRoutes = require("./v1/me");
const historyRoutes = require("./v1/history");
const statsRoutes = require("./v1/stats_routes");
const uploadImageRoutes = require("./v1/uploadImage_route");
const searchRoutes = require("./v1/search_routes");
const freshStartRoutes = require("./v1/freshStart");
const config = require("./config/config.json");

const redisClient = require("./dbredis");

const cachingBool = Boolean(config.caching);

// process.env.NODE_ENV = "development";

const options = {
  key: fs.readFileSync(path.join(__dirname, "./cert/key.pem")),
  cert: fs.readFileSync(path.join(__dirname, "./cert/cert.pem")),
};

const limiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  limit: 350, // Limit each IP to 350 requests per `window` (here, per 10 minutes).
  standardHeaders: "draft-7", // draft-6: `RateLimit-*` headers; draft-7: combined `RateLimit` header
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers.
  // store: ... , // Use an external store for consistency across multiple server instances.
});

const app = express();
const subdirectory = "/api";
const latestVersion = "/v1";

const v1path = subdirectory + latestVersion;

createDirectories();

app.use(v1path, statsRoutes);

app.set("trust proxy", 1);

// access images on path
// http://<ip>:<port>/files/<low/original>/<image file name>
app.use("/files", express.static(__dirname + "/upload"));

app.use("/favicon.ico", express.static("./static/favicon.ico"));

app.use(express.urlencoded({ extended: false }));
app.use(helmet());
app.use(
  morgan(
    ":date[web] :remote-addr  :method :url :status - :response-time ms :res[content-length]"
  )
);
app.use(limiter);
app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);

app.use(v1path, userRoutes);
app.use(v1path, communityRoutes);
app.use(v1path, postRoutes);
app.use(v1path, commentRoutes);
app.use(v1path, votesRoutes);
app.use(v1path, reportRoutes);
app.use(v1path, meRoutes);
app.use(v1path, historyRoutes);
app.use(v1path, searchRoutes);
app.use(v1path, freshStartRoutes);
app.use(uploadImageRoutes);

app.get("/ip", (request, response) => response.send(request.ip));

app.get("/version-apk", async (request, response) => {
  if (cachingBool) {
    const apkversion = await redisClient.get(`version-apk`, config.apkversion);

    if (apkversion) {
      return response.send(apkversion);
    }
  }
  var apkversion = config.apkversion;

  if (cachingBool) {
    await redisClient.set(`version-apk`, config.apkversion);
  }

  return response.send(apkversion);
});

process.on("SIGINT", async () => {
  console.log("Ctrl-C was pressed");
  process.exit();
});

http.createServer(app.handle.bind(app)).listen(3001, () => {
  console.log(`server is listening on port 3001`);
});

https
  .createServer(
    {
      // ca: fs.readFileSync("./server.ca-bundle"),
      key: fs.readFileSync("./cert/key.pem"),
      cert: fs.readFileSync("./cert/cert.pem"),
    },
    app.handle.bind(app)
  )
  .listen(3002, () => {
    console.log(`Secure server is listening on port 3002`);
  });
