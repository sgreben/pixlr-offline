package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"sync"

	"github.com/gobuffalo/packr"
	_ "github.com/gobuffalo/packr/packr/cmd"
	"github.com/skratchdot/open-golang/open"
)

//go:generate make static/patched

var config struct {
	Listen       string
	DoNotOpenURL bool
}

func init() {
	log.SetOutput(os.Stderr)
	log.SetFlags(log.Lshortfile | log.Ldate)
	flag.StringVar(&config.Listen, "listen", ":3000", "address to serve the editor on")
	flag.BoolVar(&config.DoNotOpenURL, "no-open", false, "do not open the app URL on launch")
	flag.Parse()
}

func main() {
	http.Handle("/", http.FileServer(packr.NewBox("./static")))

	var wg sync.WaitGroup

	wg.Add(1)
	go func() {
		defer wg.Done()
		log.Println("listening on", config.Listen)
		http.ListenAndServe(config.Listen, nil)
	}()

	if !config.DoNotOpenURL {
		wg.Add(1)
		go func() {
			defer wg.Done()
			appURL := fmt.Sprintf("http://localhost%s", config.Listen)
			log.Println("opening", appURL)
			open.Run(appURL)
		}()
	}

	wg.Wait()
}
