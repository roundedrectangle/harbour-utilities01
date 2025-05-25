%define package_library "no"
# See README

Name:       harbour-utilities01

Summary:    Simple utilities
Version:    0.1a1
Release:    1
License:    LICENSE
URL:        http://example.org/
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils
Requires:   pyotherside-qml-plugin-python3-qt5

%if %{package_library} == "yes"
BuildRequires: python3-base
BuildRequires: python3-devel
BuildRequires: python3-pip
BuildRequires: git
%endif
%if %{package_library} == "no"
Requires: python3-base
Requires: gcc
Requires: python3-devel
Requires: python3-pip
%endif

%define __provides_exclude_from ^%{_datadir}/.*$
%global _missing_build_ids_terminate_build 0

%description
Utilities is an application where you can download, upload and use small utility applications.


%prep
%setup -q -n %{name}-%{version}

%build

%qmake5

%make_build


%if %{package_library} == "yes"
python3 -m pip install --force-reinstall --no-cache-dir "https://github.com/roundedrectangle/pyotherside-utils/releases/download/latest/pyotherside_utils-1.0-py3-none-any.whl" --target=%_builddir/deps
python3 -m pip install --upgrade httpx attrs cattrs --target=%_builddir/deps
rm -rf %_builddir/deps/bin
%endif

%install
%qmake5_install

%if %{package_library} == "yes"
mkdir -p %{buildroot}%{_datadir}/%{name}/lib/
cp -r deps %{buildroot}%{_datadir}/%{name}/lib/deps
%endif

desktop-file-install --delete-original         --dir %{buildroot}%{_datadir}/applications                %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
