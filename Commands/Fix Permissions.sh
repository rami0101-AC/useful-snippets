Script based on guidelines given above #
If you need to fix permissions repeatedly then the following script will help you, it is based on the guidelines given above and performs some checks before any modification to ensure it is not applied on files/directories outside your Drupal installation.

#!/bin/bash

# Help menu
print_help() {
cat <<-HELP
This script is used to fix permissions of a Drupal installation
you need to provide the following arguments:

  1) Path to your Drupal installation.
  2) Username of the user that you want to give files/directories ownership.
  3) HTTPD group name (defaults to www-data for Apache).

Usage: (sudo) bash ${0##*/} --drupal_path=PATH --drupal_user=USER --httpd_group=GROUP
Example: (sudo) bash ${0##*/} --drupal_path=/usr/local/apache2/htdocs --drupal_user=john --httpd_group=www-data
HELP
exit 0
}

if [ $(id -u) != 0 ]; then
  printf "**************************************\n"
  printf "* Error: You must run this with sudo or root*\n"
  printf "**************************************\n"
  print_help
  exit 1
fi

drupal_path=${1%/}
drupal_user=${2}
httpd_group="${3:-www-data}"

# Parse Command Line Arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --drupal_path=*)
        drupal_path="${1#*=}"
        ;;
    --drupal_user=*)
        drupal_user="${1#*=}"
        ;;
    --httpd_group=*)
        httpd_group="${1#*=}"
        ;;
    --help) print_help;;
    *)
      printf "***********************************************************\n"
      printf "* Error: Invalid argument, run --help for valid arguments. *\n"
      printf "***********************************************************\n"
      exit 1
  esac
  shift
done

if [ -z "${drupal_path}" ] || [ ! -d "${drupal_path}/sites" ] || [ ! -f "${drupal_path}/core/modules/system/system.module" ] && [ ! -f "${drupal_path}/modules/system/system.module" ]; then
  printf "*********************************************\n"
  printf "* Error: Please provide a valid Drupal path. *\n"
  printf "*********************************************\n"
  print_help
  exit 1
fi

if [ -z "${drupal_user}" ] || [[ $(id -un "${drupal_user}" 2> /dev/null) != "${drupal_user}" ]]; then
  printf "*************************************\n"
  printf "* Error: Please provide a valid user. *\n"
  printf "*************************************\n"
  print_help
  exit 1
fi

cd $drupal_path
printf "Changing ownership of all contents of "${drupal_path}":\n user => "${drupal_user}" \t group => "${httpd_group}"\n"
chown -R ${drupal_user}:${httpd_group} .

printf "Changing permissions of all directories inside "${drupal_path}" to "rwxr-x---"...\n"
find . -type d -exec chmod u=rwx,g=rx,o= '{}' \;

printf "Changing permissions of all files inside "${drupal_path}" to "rw-r-----"...\n"
find . -type f -exec chmod u=rw,g=r,o= '{}' \;

printf "Changing permissions of "files" directories in "${drupal_path}/sites" to "rwxrwx---"...\n"
cd sites
find . -type d -name files -exec chmod ug=rwx,o= '{}' \;

printf "Changing permissions of all files inside all "files" directories in "${drupal_path}/sites" to "rw-rw----"...\n"
printf "Changing permissions of all directories inside all "files" directories in "${drupal_path}/sites" to "rwxrwx---"...\n"
for x in ./*/files; do
  find ${x} -type d -exec chmod ug=rwx,o= '{}' \;
  find ${x} -type f -exec chmod ug=rw,o= '{}' \;
done
echo "Done setting proper permissions on files and directories"
Copy the code above to a file, name it "~/fix-permissions.sh" and run it as follows:
sudo bash ~/fix-permissions.sh --drupal_path=your/drupal/path --drupal_user=your_user_name

Note: The server group name is assumed "www-data", if it differs use the --httpd_group=GROUP argument.

If you have sufficient privileges on your server

Place the file in /usr/local/bin
sudo chown root:root /usr/local/bin/~/fix-permissions.sh
sudo vi /etc/sudoers.d/fix-permissions and enter the following line in the file
user1, user2 ALL = (root) NOPASSWD: /usr/local/bin/~/fix-permissions.sh
Save the file and then sudo chmod 0440 /etc/sudoers.d/fix-permissions
Note: Substitute your desired comma separated list of users where you see user1, user2 above. Alternatively, you could enter an ALIAS for a user list. Run man sudoers for more information on formatting the line.

What the /etc/sudoers.d/fix-permissions accomplishes is making the script available to a set of users via the sudo command without having to enter a password.

Assuming that /usr/local/bin is in the user's path (and it should be), then the script can be run from anywhere using

sudo ~/fix-permissions.sh \
--drupal_path=/path/to/the/drupal/install \
--drupal_user=your_desired_user
.

Note: The "\" is being used here to help avoid bad line breaks in the display of the page.