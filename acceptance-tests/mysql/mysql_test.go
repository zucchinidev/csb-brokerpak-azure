package mysql_test

import (
	"acceptancetests/helpers"
	"fmt"
	"os"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("MySQL", func() {
	var serviceInstanceName string

	BeforeEach(func() {
		serviceInstanceName = helpers.RandomName("mysql")
		helpers.CreateService("csb-azure-mysql", "small", serviceInstanceName)
	})

	AfterEach(func() {
		helpers.DeleteService(serviceInstanceName)
	})

	It("can be accessed by an app", func() {
		By("building the app")
		appDir := helpers.AppBuild("./mysqlapp")
		defer os.RemoveAll(appDir)

		By("pushing the unstarted app twice")
		appOne := helpers.AppPushUnstartedBinaryBuildpack("mysql", appDir)
		appTwo := helpers.AppPushUnstartedBinaryBuildpack("mysql", appDir)
		defer helpers.AppDelete(appOne, appTwo)

		By("binding the apps to the service instance")
		bindingName := helpers.Bind(appOne, serviceInstanceName)
		helpers.Bind(appTwo, serviceInstanceName)

		By("starting the apps")
		helpers.AppStart(appOne, appTwo)

		By("checking that the app environment has a credhub reference for credentials")
		creds := helpers.GetBindingCredential(appOne, "csb-azure-mysql", bindingName)
		Expect(creds).To(HaveKey("credhub-ref"))

		By("setting a key-value using the first app")
		key := helpers.RandomString()
		value := helpers.RandomString()
		helpers.HTTPPut(fmt.Sprintf("http://%s.%s/%s", appOne, helpers.DefaultSharedDomain(), key), value)

		By("getting the value using the second app")
		got := helpers.HTTPGet(fmt.Sprintf("http://%s.%s/%s", appTwo, helpers.DefaultSharedDomain(), key))
		Expect(got).To(Equal(value))
	})
})
