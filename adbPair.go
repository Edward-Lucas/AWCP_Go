package main

import (
	"bytes"
	"context"
	"fmt"
	"github.com/grandcat/zeroconf"
	"github.com/mdp/qrterminal"
	"log"
	"math/rand"
	"os"
	"os/exec"
	"strings"
	"time"
)

var letterRunes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890$"

func RandStringRunes(n int) string {
	b := make([]byte, n)
	for i := range b {
		b[i] = letterRunes[rand.Intn(len(letterRunes))]
	}
	return string(b)
}

var serviceId string
var password string

func main() {
	serviceId = fmt.Sprintf("studio-%s", RandStringRunes(8))
	password = RandStringRunes(8)
	if TestSixelSupport(os.Stdout) {
		buf := bytes.NewBufferString("")
		qrterminal.Generate(fmt.Sprintf("WIFI:T:ADB;S:%s;P:%s;;", serviceId, password), qrterminal.M, buf)
		SixelPrint(buf.String())
	} else {
		qrterminal.GenerateHalfBlock(fmt.Sprintf("WIFI:T:ADB;S:%s;P:%s;;", serviceId, password), qrterminal.M, os.Stdout)
	}

	cmd := exec.Command("adb", "mdns", "check")
	var res []byte
	var err error

	if res, err = cmd.CombinedOutput(); err != nil {
		if strings.Contains(string(res), "unknown command") {
			fmt.Println(string(res))
		}
		//	fmt.Println(err)
		//	if(err.)
		//	os.Exit(1)
	}
	resolver, err := zeroconf.NewResolver(nil)
	if err != nil {
		fmt.Println("❌ Failed to initialize resolver:", err.Error())
	}

	entries := make(chan *zeroconf.ServiceEntry)

	ctx, cancel := context.WithTimeout(context.Background(), time.Second*60)
	defer cancel()
	go func(results <-chan *zeroconf.ServiceEntry) {
		for entry := range results {
			//log.Println(entry)
			if entry.ServiceRecord.Instance == serviceId {
				fmt.Println("🚀 기기를 찾았습니다. 연결 중...")

				cmd := exec.Command("adb", "pair", fmt.Sprintf("%s:%d", entry.AddrIPv4, entry.Port), password)
				fmt.Println(fmt.Sprintf("%s:%d", entry.AddrIPv4, entry.Port), password)
				var res []byte
				var err error

				if res, err = cmd.CombinedOutput(); err != nil {
					if strings.Contains(string(res), "unknown command") {
						fmt.Println("⚠️ ADB 버전이 pair 기능을 지원하지 않습니다. ADB 서비스 프로토콜을 사용해 보세요.")
						adbConnect := fmt.Sprintf("host:pair:%s:%s", password, fmt.Sprintf("%s:%d", entry.AddrIPv4, entry.Port))
						connection := AdbConnection{}
						connection.Init("tcp:127.0.0.1:5037")
						connection.writeString(adbConnect)
						var status string
						status, err = connection.readStatus()
						status = strings.ToLower(status)
						if err != nil {
							res = []byte(fmt.Sprintf("Failed: %s", err.Error()))
						}
						if strings.Contains(status, "okay") {
							res = []byte("Successfully paired")
						} else {
							res = []byte(fmt.Sprintf("Failed: %s", status))
						}

					} else {
						fmt.Println(string(res))
					}

				}

				if strings.Contains(string(res), "Failed:") {
					fmt.Println("❌ 연결 실패:" + string(res))
					os.Exit(1)
				}
				fmt.Println(string(res))

				if strings.Contains(string(res), "Successfully") {
					fmt.Println("🚀 연결 성공: " + string(res))
					os.Exit(0)
				}
			}

		}
		fmt.Println("No more entries.")
	}(entries)
	err = resolver.Browse(ctx, "_adb-tls-pairing._tcp", "local.", entries)
	if err != nil {
		log.Fatalln("기기 검색 실패", err.Error())
	}

	<-ctx.Done()

	fmt.Println(string(res))

}
