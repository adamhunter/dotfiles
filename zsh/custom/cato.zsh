# Cato's TLS-inspecting proxy re-signs HTTPS with its own root CA, which node
# rejects unless pointed at the CA bundle.
#
# Only export when the file is actually there: the CA is installed by the Cato
# client, which runs on the laptop and not on the Linux dev boxes, and node
# aborts at startup if NODE_EXTRA_CA_CERTS names a file it cannot read.
[ -r "$HOME/.cato-root-ca.pem" ] && export NODE_EXTRA_CA_CERTS="$HOME/.cato-root-ca.pem"
