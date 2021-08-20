apt-get install git uuid uuid-dev libssl-dev
git clone git://git.eclipse.org/gitroot/tcf/org.eclipse.tcf.agent.git
cd org.eclipse.tcf.agent/agent
make install    # (Review the files being installed into /tmp)
make install INSTALLROOT=
update-rc.d tcf-agent defaults