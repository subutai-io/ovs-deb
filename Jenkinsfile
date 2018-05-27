#!groovy

notifyBuildDetails = ""
agentCommitId = ""

try {
	notifyBuild('STARTED')
	node("deb") {
		deleteDir()
     
		stage("Checkout source")
		
		notifyBuildDetails = "\nFailed on Stage - Checkout source"
				
		String date = new Date().format( 'yyyyMMddHHMMSS' )
		def CWD = pwd()

                switch (env.BRANCH_NAME) {
                    case ~/master/: 
                        cdnHost = "mastercdn.subutai.io"; 
                        break;
                    case ~/dev/: 
                        cdnHost = "devcdn.subutai.io"; 
                        break;
                    case ~/no-snap/: 
                        cdnHost = "devcdn.subutai.io"; 
                        break;
                    case ~/sysnet/: 
                        cdnHost = "sysnetcdn.subutai.io"; 
                        break;
                    default: 
                        cdnHost = "cdn.subutai.io"; 
                }
                def release = env.BRANCH_NAME

		sh """
			#set +x
			export LC_ALL=C.UTF-8
			export LANG=C.UTF-8
			rm -rf *
			cd ${CWD} || exit 1

			# Clone ovs-deb code
			git clone https://github.com/subutai-io/ovs-deb
			cd ovs-deb
			git checkout ${release}
		"""		
		stage("Tweaks for version")
		notifyBuildDetails = "\nFailed on Stage - Version tweaks"
		sh """
                        cd ${CWD}/ovs-deb || exit 1
                        ovs-deb_version=\$(git describe --abbrev=0 --tags)+\$(date +%Y%m%d%H%M%S0)
			echo "VERSION is \$ovs-deb_version"

			cd ${CWD}/ovs-deb && sed -i 's/quilt/native/' debian/source/format
			dch -v "\$ovs-deb_version" -D stable "Test build for \$ovs-deb_version" 1>/dev/null 2>/dev/null
		"""

		stage("Build subutai-ovs package")
		notifyBuildDetails = "\nFailed on Stage - Build package"
		sh """
			cd ${CWD}/ovs-deb
			dpkg-buildpackage -rfakeroot

			cd ${CWD} || exit 1
			for i in *.deb; do
    		            echo '\$i:';
    		            dpkg -c \$i;
			done
		"""
		
		stage("Upload Packages")
		notifyBuildDetails = "\nFailed on Stage - Upload"
		sh """
			cd ${CWD}
			touch uploading_ovs
			scp uploading_ovs subutai*.deb dak@deb.subutai.io:incoming/${release}/
			ssh dak@deb.subutai.io sh /var/reprepro/scripts/scan-incoming.sh ${release} ovs
		"""
	}

} catch (e) { 
	currentBuild.result = "FAILED"
	throw e
} finally {
	// Success or failure, always send notifications
	notifyBuild(currentBuild.result, notifyBuildDetails)
}

// https://jenkins.io/blog/2016/07/18/pipline-notifications/
def notifyBuild(String buildStatus = 'STARTED', String details = '') {
  // build status of null means successful
  buildStatus = buildStatus ?: 'SUCCESSFUL'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"  	
  def summary = "${subject} (${env.BUILD_URL})"

  // Override default values based on build status
  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'  
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
	summary = "${subject} (${env.BUILD_URL})${details}"
  }
  // Get token
  def slackToken = getSlackToken('sysnet')
  // Send notifications
  slackSend (color: colorCode, message: summary, teamDomain: 'optdyn', token: "${slackToken}")
}

// get slack token from global jenkins credentials store
@NonCPS
def getSlackToken(String slackCredentialsId){
	// id is ID of creadentials
	def jenkins_creds = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0]

	String found_slack_token = jenkins_creds.getStore().getDomains().findResult { domain ->
	  jenkins_creds.getCredentials(domain).findResult { credential ->
	    if(slackCredentialsId.equals(credential.id)) {
	      credential.getSecret()
	    }
	  }
	}
	return found_slack_token
}
