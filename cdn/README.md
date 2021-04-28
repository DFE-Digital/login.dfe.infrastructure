*CDN Migration Overview*

A migration from the Standard Verizon to the Premium Verizon CDN is required to support CORS.

Premium Verizon enables use of the rules engine which allows us to add policies.

These ensure the Access-Control-Allow-Origin header is returned for requests made from domains that match the regex (https?:\/\/([a-z]*-*[a-z]*\.signin\.education\.gov\.uk)$) currently defined in the policy.

This matches requests from the following formats and therefore covers development, testing and production environments.

- https://env-application.signin.education.gov.uk
- https://application.signin.education.gov.uk


To add a policy:

- Navigate to the CDN profile in the Azure Portal.
- Click 'Manage'.
- Under the 'HTTP Large' menu click 'Rules Engine V4.0'.
- Click '+ New' in the 'Drafts' tab.
- Enter a name and click 'Continue'.
- On the 'Raw XML' tab click 'Import' and navigate to the policy XML file.
- Click 'Lock Draft as Policy' > 'Deploy Request'.
- Select Production from the 'Environment' drop down list and click 'Create Deploy Request'.
- The policy should be deployed to the production environment.


To set compression which has to be removed from the endpoint ARM template. The default list covers those types previously set in the CDN endpoint ARM template.

- Under the 'HTTP Large' menu click 'Cache Settings' > 'Compression'.
- Select the 'Compression Enabled' checkbox and click 'Update'.
