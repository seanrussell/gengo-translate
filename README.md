# Gengo Translate

[![CircleCI](https://circleci.com/gh/seanrussell/gengo-translate.svg?style=svg)](https://circleci.com/gh/seanrussell/gengo-translate)

## Gengo Integration
![Gengo Translate Integration](/assets/gengo-translate.png)

## Installing Gengo Translate using a Scratch Org

1. Set up your environment. Follow the steps in the [Quick Start: Lightning Web Components](https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/) Trailhead project. The steps include:

-   Enable Dev Hub in your Trailhead Playground
-   Install Salesforce CLI
-   Install Visual Studio Code
-   Install the Visual Studio Code Salesforce extensions, including the Lightning Web Components extension

2. If you haven't already done so, authenticate with your hub org and provide it with an alias (**myhuborg** in the command below):

```
sfdx force:auth:web:login -d -a myhuborg
```

3. Clone the repository:

```
git clone https://github.com/seanrussell/gengo-translate.git
cd gengo-translate
```

4. Create a scratch org:

```
sfdx force:org:create -s -f config/project-scratch-def.json
```

5. Push the app to your scratch org:

```
sfdx force:source:push
```

6. Assign the **Translation Manager** permission set to the default user:

```
sfdx force:user:permset:assign -n Translation_Manager

```

7. Open the scratch org:

```
sfdx force:org:open
```

8. Register domain
- In order to use lightning components, you must register a unique [domain](https://help.salesforce.com/articleView?id=domain_mgmt_add.htm&type=5) for your org.

9. Create a Site
- Create a public [site](https://help.salesforce.com/articleView?id=sites_creating_and_editing_sites.htm&type=5).
- The api name for the site should be "Gengo_Public".
- Add GengoCallbackHandler apex class to public site access settings.
- Finally, activate the site.

10. Modify Record Page layouts and add the gengoTranslate component
	- For example, modify the Case record page layout to add the gengoTranslate component to the page.