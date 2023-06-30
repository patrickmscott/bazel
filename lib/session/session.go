package session

import (
	"crypto/tls"
	"net/http"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/aws/aws-sdk-go/aws/session"
)

func New() *session.Session {
	cfg := aws.NewConfig()
	localstack := os.Getenv("DOCKER_LOCALSTACK_ADDR")
	if localstack != "" {
		cfg = cfg.WithEndpoint(localstack).
			WithRegion(endpoints.UsEast1RegionID).
			WithS3ForcePathStyle(true).
			WithCredentials(credentials.AnonymousCredentials).
			WithHTTPClient(&http.Client{
				Transport: &http.Transport{
					TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
				},
			})
	}
	return session.Must(session.NewSession(cfg))
}
