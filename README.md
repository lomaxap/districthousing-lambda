# District Housing on AWS Lambda

Lambda port of just the PDF-filling bits of [District Housing](https://github.com/codefordc/districthousing) Rails app.

- uses pdftk binary from [lambda-pdftk-example](https://github.com/lob/lambda-pdftk-example)
- lambda/traveling ruby deploy script from [ruby-on-lambda](https://github.com/lorennorman/ruby-on-lambda)

## Usage

1. Sign up for Amazon AWS
2. Get access to Amazon S3
3. Get access to Amazon Lambda
4. Create an IAM account with access to S3 and Lambda
5. Install the aws cli tools
6. Set up an AWS profile in `~/.aws/credentials` for the account created above
7. Change the variables in `deploy.sh` to match your app and AWS settings
8. Ensure you're using ruby 2.1.x in this directory
9. Ensure you're using Bundler version 1.9.9
10. make `bin/` directory at root and copy pdftk/libgcj binaries from [here](https://github.com/lob/lambda-pdftk-example)
11. run `./deploy.sh linux-x86_64`
12. test your Lambda Function!
