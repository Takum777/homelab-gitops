{
  "identities": [
    {
      "name": "terraform",
      "credentials": [
        {
          "accessKey": "${AWS_ACCESS_KEY_ID}",
          "secretKey": "${AWS_SECRET_ACCESS_KEY}"
        }
      ],
      "actions": ["Read:tfstate", "Write:tfstate", "List:tfstate"]
    }
  ]
}
