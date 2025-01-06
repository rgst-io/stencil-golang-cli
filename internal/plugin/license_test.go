package plugin_test

import (
	"context"
	"testing"

	"github.com/google/go-github/v68/github"
	"github.com/rgst-io/stencil-golang/internal/plugin"
	"go.rgst.io/stencil/v2/pkg/extensions/apiv1"
	"gotest.tools/v3/assert"
)

func TestCanGetLicenseByName(t *testing.T) {
	ctx := context.Background()
	p := plugin.New(ctx)

	license, err := p.GetLicense(&apiv1.TemplateFunctionExec{
		Arguments: []any{"LGPL-3.0"},
	})
	assert.NilError(t, err)
	assert.Equal(t, license.(*github.License).GetSPDXID(), "LGPL-3.0")
}
