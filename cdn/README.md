*CDN Migration Overview*

A migration from the Standard Verizon to the Premium Verizon CDN is required to support CORS.

Premium Verizon enables use of the rules engine which allows us to add policies.

These ensure the Access-Control-Allow-Origin header is returned for requests made from domains that match the regex (https?:\/\/([a-z]*-*[a-z]*\.signin\.education\.gov\.uk)$) currently defined in the policy.

This matches requests from the following formats and therefore covers development, testing and production environments.

https://env-application.signin.education.gov.uk

https://application.signin.education.gov.uk
