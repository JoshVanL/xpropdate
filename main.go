package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"time"
)

func main() {
	if _, err := exec.LookPath("xprop"); err != nil {
		fatal(fmt.Errorf("failed to find xprop: %w", err))
	}

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, os.Kill)
	defer cancel()

	for {
		now := time.Now().Local()

		dateString := fmt.Sprintf("%d/%.2d/%.2d %.2d:%.2d",
			now.Year(), now.Month(), now.Day(), now.Hour(), now.Minute(),
		)

		cmd := exec.CommandContext(ctx, "xprop", "-root", "-set", "WM_NAME", dateString)
		if err := cmd.Run(); err != nil {
			fatal(fmt.Errorf("failed to run xprop: %w", err))
		}

		uni := now.Unix()
		nextMin := time.Unix((uni-uni%60)+60, 0)
		select {
		case <-ctx.Done():
			return
		case <-time.Tick(time.Until(nextMin)):
		}
	}
}

func fatal(err error) {
	fmt.Fprintf(os.Stderr, "error: %s\n", err)
	os.Exit(1)
}
