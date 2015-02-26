# dockerfile-jenkins
Jenkins Master with external uid/gid capabilities

# exemple run
docker run --name jenkins-master  -e uid=30002 -e gid=30002 -d -p 127.0.0.1:8091:8080 -v /opt/docker-volumes/jenkins:/var/jenkins_home cyphermaster/jenkins

# cfengine incomplete snippet
~~~~
bundle agent app_ci_jenkins_autorun
{

  meta:
      "tags" slist => { "autorun" };
vars:
        "ci_user"       string => "jenkins";
        "ci_uid"        string => "30002";
        "override_dir"  string => "/opt/docker-volumes/jenkins";

users:
         "$(ci_user)"
            policy => "present",
            uid => "$(ci_uid)",
            description => "jenkins user",
            home_dir => "$(override_dir)",
            group_primary => "$(ci_user)",
            groups_secondary => { "$(ci_user)" },
            shell => "/bin/true";
files:
        "$(override_dir)/."
                comment => "Assure que les fichier peuvent etre lus",
                perms => mog("640", "$(ci_user)","$(ci_user)"),
                depth_search => include_base,
                file_select => default:all,
                create => "true",
                action => if_elapsed("60");
}
~~~~
# incomplete nginx proxypass
~~~~
upstream jenkins {
        server localhost:8091;
        keepalive 512;
}

server {
        listen 443 ssl;
        server_name ci.example.org;
        access_log      /var/log/nginx/ci-access.log;
        error_log       /var/log/nginx/ci-error.log error;


        location / {
        proxy_pass         http://jenkins;
        }
}
~~~~
