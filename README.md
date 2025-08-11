# devenv

I'm experimenting with containerised dev environments mainly for security reasons. I want to reduce the blast radius should something malicious be present on my machine, or an LLM-based tool gets tricked into nuking my home directory. I'm not really comfortable with running AI tooling under my own user while prompt injection is still a thing.

Obviously, containers do not provide a strong security boundary, but they're strong enough for all but the most sophisticated attacks. I'm not important enough for an attacker to burn a container zero day on me. In addition, I work on a MacBook and use OrbStack which runs containers in a VM, so they're at least not running in the same address space.

Currently I'm creating a separate development environment container for each project. This way, if one container is compromised, source code and secrets from other projects are protected and blast radius is minimised.

The project containers have restricted network access -- they're on an internal Docker network and can only send outbound HTTP(S) requests via a proxy container which has a domain whitelist.

I'd like to find a way to create project-specific GitHub tokens so that each container can only read/write to a single repository under my own user. It seems that Personal Access Tokens (PATs) can only be manually created and I'm too lazy to manage a PAT for every project, but maybe there's some other way.

I'm also experimenting with a container 'sidecar' mechanism. Similar to Kubernetes' sidecar concept, I'm giving each project container a sidecar in the same Docker network. The sidecar is also part of another Docker network intended to run a metadata API. The end goal is that the sidecar facilitates a cloud-like metadata API and a way for the metadata API to verify a client's pod identity. This pod identity could be used to gain access to secrets similar to how EKS Pod Identity works.

Lastly, I need to provide containers a way to use my SSH key stored in Secretive on the host. This might be as easy as passing through the Secretive SSH socket. Or maybe I'll go back to using a YubiKey.

I'm building all of this using Terraform, which I took inspiration for from [Coder](https://coder.com/). I tried out Coder and I think it's really cool, but too heavyweight for my purposes.
