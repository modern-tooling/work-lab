# Copyright (c) 2026 Ryan Snodgrass. MIT License.
# Homebrew formula for work-lab
#
# To use this formula:
# 1. Create a homebrew tap repo: github.com/modern-tooling/homebrew-tap
# 2. Copy this file to that repo as Formula/work-lab.rb
# 3. Users can then: brew tap modern-tooling/tap && brew install work-lab

class WorkLab < Formula
  desc "Container-based lab for humans and AI coding agents"
  homepage "https://github.com/modern-tooling/work-lab"
  url "https://github.com/modern-tooling/work-lab.git", tag: "v1.0.0"
  license "MIT"
  head "https://github.com/modern-tooling/work-lab.git", branch: "main"

  depends_on "docker"

  def install
    # Install the entire repo to libexec
    libexec.install Dir["*"]
    libexec.install Dir[".*"].reject { |f| f =~ /^\.\.?$/ }

    # Symlink the bin script
    bin.install_symlink libexec/"bin/work-lab"

    # Create config directory hint
    ohai "work-lab installed!"
    ohai "Create your config directory: mkdir -p ~/.config/work-lab"
  end

  def caveats
    <<~EOS
      work-lab has been installed.

      To get started:
        work-lab doctor   # Check your environment
        work-lab start    # Start the container
        work-lab mux      # Attach to tmux session

      Optional: Create custom hooks in ~/.config/work-lab/
        post-create.sh    # Runs once after container creation
        post-start.sh     # Runs every time container starts
    EOS
  end

  test do
    assert_match "work-lab", shell_output("#{bin}/work-lab help")
  end
end
