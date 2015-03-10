#! /bin/bash -x

# Copy files from /usr/share/jenkins/ref into /var/jenkins_home
# So the initial JENKINS-HOME is set with expected content. 
# Don't override, as this is just a reference setup, and use from UI 
# can then change this, upgrade plugins, etc.
copy_reference_file() {
	f=${1%/} 
	echo "$f"
    rel="${f:23}"
    dir=$(dirname "${f}")
    echo " $f -> $rel"    
	if [[ ! -e "/var/jenkins_home/${rel}" ]]; then
		echo "copy $rel to JENKINS_HOME"
		mkdir -p "/var/jenkins_home/${dir:23}"
		cp -r "/usr/share/jenkins/ref/${rel}" "/var/jenkins_home/${rel}"
  fi 
}
groupadd jenkins --gid "${gid:-1000}"
useradd -d "$JENKINS_HOME" -u "${uid:-1000}" --gid "${gid:-1000}" -m -s /bin/bash jenkins
chown -R jenkins "$JENKINS_HOME" /usr/share/jenkins/ref /usr/share/jenkins/jenkins.war
export -f copy_reference_file

su jenkins << EOF
find /usr/share/jenkins/ref/ -type f -exec bash -c 'copy_reference_file {}' \;
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
   exec java "$JAVA_OPTS" -jar /usr/share/jenkins/jenkins.war "$JENKINS_OPTS" "$@"
fi
exec "$@"
EOF

su jenkins << EOF
find /usr/share/jenkins/ref/ -type f -exec bash -c 'copy_reference_file {}' \;
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
     exec java $JAVA_OPTS -jar /usr/share/jenkins/jenkins.war $JENKINS_OPTS "$@"
fi
exec "$@"
EOF

