export default {
  token: {
    url: "https://signin-pr-dirlnx-as.azurewebsites.net",
    auth: {
      type: process.env.TOKEN_TYPE,
      tenant: process.env.TOKEN_TENANT,
      authorityHostUrl: process.env.TOKEN_AUTHORITY_HOST,
      clientId: process.env.TOKEN_CLIENT_ID,
      clientSecret: process.env.TOKEN_CLIENT_SECRET,
      resource: process.env.TOKEN_RESOURCE
    }
  },

  endpoint: "signin-pr-jobslnx-as.azurewebsites.net",
  wait: process.env.JOB_CLEARANCE_WAIT
};
