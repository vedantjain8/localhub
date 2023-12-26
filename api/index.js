const express = require("express");
const bodyParser = require("body-parser");
const helmet = require("helmet");
const { rateLimit } = require("express-rate-limit");
const morgan = require("morgan");
const https = require("https");
const fs = require("fs");
const path = require("path");

const userRoutes = require("./v1/user_routes");
const subredditRoutes = require("./v1/subreddit_routes");
const postRoutes = require("./v1/post_routes");
const loginRoutes = require("./v1/login_routes");
const commentRoutes = require("./v1/comments_routes");
const votesRoutes = require("./v1/votes_routes");
const reportRoutes = require("./v1/report_routes");
const meRoutes = require("./v1/me");
const historyRoutes = require("./v1/history");

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
const port = 3000;
const subdirectory = "/api";
const latestVersion = "/v1";

const v1path = subdirectory + latestVersion;

app.set("trust proxy", 1);
app.get("/ip", (request, response) => response.send(request.ip));

// app.use(helmet());
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
app.use(v1path, subredditRoutes);
app.use(v1path, postRoutes);
app.use(v1path, loginRoutes);
app.use(v1path, commentRoutes);
app.use(v1path, votesRoutes);
app.use(v1path, reportRoutes);
app.use(v1path, meRoutes);
app.use(v1path, historyRoutes);

// app.listen(port, () => {
//   console.log(`Server is running on http://localhost:${port}`);
// });

process.on("SIGINT", () => {
  console.log("Ctrl-C was pressed");
  process.exit();
});

const sslServer = https.createServer(options, app);
sslServer.listen(1337, () => {
  console.log("Secure server is listening on port 1337");
});
