Name:     cookbook-n2klocd
Version:  %{__version}
Release:  %{__release}%{?dist}
BuildArch: noarch
Summary: n2klocd cookbook to install and configure it in redborder environments

License:  GNU AGPLv3
URL: https://github.com/redBorder/cookbook-n2klocd
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/n2klocd
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/n2klocd/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/n2klocd
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/n2klocd/README.md

%pre
if [ -d /var/chef/cookbooks/n2klocd ]; then
    rm -rf /var/chef/cookbooks/n2klocd
fi

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload n2klocd'
  ;;
esac

%postun
# Deletes directory when uninstall the package
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/n2klocd ]; then
  rm -rf /var/chef/cookbooks/n2klocd
fi

systemctl daemon-reload
%files
%defattr(0755,root,root)
/var/chef/cookbooks/n2klocd
%defattr(0644,root,root)
/var/chef/cookbooks/n2klocd/README.md

%doc

%changelog
* Thu Oct 10 2024 Miguel Negrón <manegron@redborder.com>
- Add pre and postun

* Wed Jan 20 2022 Eduardo Reyes <eareyes@redborder.com>
- first spec version
