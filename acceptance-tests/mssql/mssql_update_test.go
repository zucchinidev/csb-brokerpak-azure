package mssql_test

import (
	"acceptancetests/apps"
	"acceptancetests/helpers"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("MSSQLUpdateService", func() {
	It("can be accessed by an app", func() {
		By("creating a service instance")
		serviceInstance := helpers.CreateServiceFromBroker("csb-azure-mssql", "small-v2", helpers.DefaultBroker().Name)
		defer serviceInstance.Delete()

		By("pushing the unstarted app twice")
		appOne := helpers.AppPushUnstarted(apps.MSSQL)
		appTwo := helpers.AppPushUnstarted(apps.MSSQL)
		defer helpers.AppDelete(appOne, appTwo)

		By("binding the apps to the service instance")
		binding := serviceInstance.Bind(appOne)
		serviceInstance.Bind(appTwo)

		By("starting the apps")
		helpers.AppStart(appOne, appTwo)

		By("checking that the app environment has a credhub reference for credentials")
		Expect(binding.Credential()).To(helpers.HaveCredHubRef)

		By("creating a schema using the first app")
		schema := helpers.RandomShortName()
		appOne.PUT("", schema)

		By("setting a key-value using the first app")
		keyOne := helpers.RandomHex()
		valueOne := helpers.RandomHex()
		appOne.PUT(valueOne, "%s/%s", schema, keyOne)

		By("getting the value using the second app")
		got := appTwo.GET("%s/%s", schema, keyOne)
		Expect(got).To(Equal(valueOne))

		By("updating the instance plan")
		serviceInstance.UpdateService("-p", "medium")

		By("checking previously written data still accessible")
		got = appTwo.GET("%s/%s", schema, keyOne)
		Expect(got).To(Equal(valueOne))

		By("checking data can still be written and read")
		keyTwo := helpers.RandomHex()
		valueTwo := helpers.RandomHex()
		appOne.PUT(valueTwo, "%s/%s", schema, keyTwo)

		got = appTwo.GET("%s/%s", schema, keyTwo)
		Expect(got).To(Equal(valueTwo))

		By("dropping the schema using the first app")
		appOne.DELETE(schema)
	})
})
