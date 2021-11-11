package mysql_test

import (
	"acceptancetests/apps"
	"acceptancetests/helpers"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("MySQLUpdateService", func() {
	It("can be accessed by an app", func() {
		By("creating a service instance")
		serviceInstance := helpers.CreateServiceFromBroker("csb-azure-mysql", "small", helpers.DefaultBroker().Name)
		defer serviceInstance.Delete()

		By("pushing the unstarted app twice")
		appOne := helpers.AppPushUnstarted(apps.MySQL)
		appTwo := helpers.AppPushUnstarted(apps.MySQL)
		defer helpers.AppDelete(appOne, appTwo)

		By("binding the apps to the service instance")
		binding := serviceInstance.Bind(appOne)
		serviceInstance.Bind(appTwo)

		By("starting the apps")
		helpers.AppStart(appOne, appTwo)

		By("checking that the app environment has a credhub reference for credentials")
		Expect(binding.Credential()).To(helpers.HaveCredHubRef)

		By("setting a key-value using the first app")
		keyOne := helpers.RandomHex()
		valueOne := helpers.RandomHex()
		appOne.PUT(valueOne, keyOne)

		By("getting the value using the second app")
		got := appTwo.GET(keyOne)
		Expect(got).To(Equal(valueOne))

		By("updating the instance plan")
		serviceInstance.UpdateService("-p", "medium")

		By("checking previously written data is still accessible")
		got = appTwo.GET(keyOne)
		Expect(got).To(Equal(valueOne))

		By("checking data can be written and read")
		keyTwo := helpers.RandomHex()
		valueTwo := helpers.RandomHex()
		appOne.PUT(valueTwo, keyTwo)

		got = appTwo.GET(keyTwo)
		Expect(got).To(Equal(valueTwo))

	})
})
