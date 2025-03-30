const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1", apiVersion: "2012-08-10" });

exports.handler = (event, context, callback) => {
  const params = { TableName: "dev-courses" }; 
  dynamodb.scan(params, (err, data) => {
    if (err) {
      console.log(err);
      callback(err);
    } else {
      const courses = data.Items.map(item => ({
        id: item.id.S,
        title: item.title.S,
        watchHref: item.watchHref.S,
        authorId: item.authorId.S,
        length: item.length.S,
        category: item.category.S
      }));
      callback(null, courses);
    }
  });
};