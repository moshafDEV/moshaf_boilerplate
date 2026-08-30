import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.example.example.staging"
            resValue(type = "string", name = "app_name", value = "Example App [DEV]")
        }
        create("staging") {
            dimension = "flavor-type"
            applicationId = "com.example.example.staging"
            resValue(type = "string", name = "app_name", value = "Example App [STAGING]")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.example.example"
            resValue(type = "string", name = "app_name", value = "Example App")
        }
    }

    buildFeatures.resValues = true
}